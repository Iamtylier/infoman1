package com.example.demo.service;

import com.example.demo.dto.MemberRequest;
import com.example.demo.dto.MemberResponse;
import com.example.demo.entity.Member;
import com.example.demo.exception.BadRequestException;
import com.example.demo.exception.ConflictException;
import com.example.demo.exception.NotFoundException;
import com.example.demo.repository.LoanRepository;
import com.example.demo.repository.MemberRepository;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MemberService {

    private final MemberRepository memberRepository;
    private final LoanRepository loanRepository;

    public MemberService(MemberRepository memberRepository, LoanRepository loanRepository) {
        this.memberRepository = memberRepository;
        this.loanRepository = loanRepository;
    }

    @Transactional(readOnly = true)
    public List<MemberResponse> findAll() {
        return memberRepository.findAll(Sort.by("id")).stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public MemberResponse findById(Long id) {
        return toResponse(memberRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Member " + id + " was not found.")));
    }

    @Transactional
    public MemberResponse create(MemberRequest request) {
        validate(request);
        String email = request.email().trim();
        if (memberRepository.existsByEmail(email)) {
            throw new ConflictException("A member with email " + email + " already exists.");
        }
        Member member = new Member(request.fullName().trim(), email, LocalDate.now());
        return toResponse(memberRepository.saveAndFlush(member));
    }

    @Transactional
    public MemberResponse update(Long id, MemberRequest request) {
        Member member = memberRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Member " + id + " was not found."));
        validate(request);
        String email = request.email().trim();
        if (memberRepository.existsByEmailAndIdNot(email, id)) {
            throw new ConflictException("Another member already uses email " + email + ".");
        }
        member.setFullName(request.fullName().trim());
        member.setEmail(email);
        return toResponse(memberRepository.saveAndFlush(member));
    }

    // Delete rule: a member who has loan records keeps them, so the member is not deleted.
    @Transactional
    public void delete(Long id) {
        if (!memberRepository.existsById(id)) {
            throw new NotFoundException("Member " + id + " was not found.");
        }
        if (loanRepository.existsByMemberId(id)) {
            throw new ConflictException("Member " + id + " has loan records and cannot be deleted.");
        }
        memberRepository.deleteById(id);
    }

    private void validate(MemberRequest r) {
        if (r == null) {
            throw new BadRequestException("The request body is required.");
        }
        if (r.fullName() == null || r.fullName().isBlank() || r.fullName().trim().length() > 100) {
            throw new BadRequestException("Full name is required (up to 100 characters).");
        }
        if (r.email() == null || r.email().isBlank() || r.email().trim().length() > 120
                || !r.email().contains("@")) {
            throw new BadRequestException("A valid email is required (up to 120 characters).");
        }
    }

    private MemberResponse toResponse(Member m) {
        return new MemberResponse(m.getId(), m.getFullName(), m.getEmail(), m.getJoinedOn().toString());
    }
}
